package org.jetbrains.bazel.sdkcompat

import com.intellij.openapi.vfs.VfsUtilCore
import com.intellij.platform.backend.workspace.virtualFile
import com.intellij.platform.workspace.storage.WorkspaceEntity
import com.intellij.platform.workspace.storage.url.VirtualFileUrl
import com.intellij.workspaceModel.core.fileIndex.WorkspaceFileSetRegistrar
import kotlin.collections.mapNotNull
import kotlin.collections.toSet

fun WorkspaceFileSetRegistrar.registerOtherRootsCompat(
  projectRoot: VirtualFileUrl,
  includedRoots: List<VirtualFileUrl>,
  entity: WorkspaceEntity,
) {
  val includedRoots = includedRoots.mapNotNull { it.virtualFile }.toSet()
  registerExclusionCondition(
    root = projectRoot,
    condition = { !VfsUtilCore.isUnderFiles(it, includedRoots) },
    entity = entity,
  )
}

const val CONTENT_NON_INDEXABLE_SUPPORTED = false
