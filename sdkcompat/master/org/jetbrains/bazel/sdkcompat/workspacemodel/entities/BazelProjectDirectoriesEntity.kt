package org.jetbrains.bazel.sdkcompat.workspacemodel.entities

import com.intellij.platform.workspace.storage.EntitySource
import com.intellij.platform.workspace.storage.EntityType
import com.intellij.platform.workspace.storage.GeneratedCodeApiVersion
import com.intellij.platform.workspace.storage.MutableEntityStorage
import com.intellij.platform.workspace.storage.WorkspaceEntity
import com.intellij.platform.workspace.storage.impl.containers.toMutableWorkspaceList
import com.intellij.platform.workspace.storage.url.VirtualFileUrl

public interface BazelProjectDirectoriesEntity : WorkspaceEntity {
  public val projectRoot: VirtualFileUrl
  public val includedRoots: List<VirtualFileUrl>
  public val excludedRoots: List<VirtualFileUrl>
  public val buildFiles: List<VirtualFileUrl>
  public val indexAllFilesInIncludedRoots: Boolean

  //region generated code
  @GeneratedCodeApiVersion(3)
  interface Builder : WorkspaceEntity.Builder<BazelProjectDirectoriesEntity> {
    override var entitySource: EntitySource
    var projectRoot: VirtualFileUrl
    var includedRoots: MutableList<VirtualFileUrl>
    var excludedRoots: MutableList<VirtualFileUrl>
    var buildFiles: MutableList<VirtualFileUrl>
    var indexAllFilesInIncludedRoots: Boolean
  }

  companion object : EntityType<BazelProjectDirectoriesEntity, Builder>() {
    @JvmOverloads
    @JvmStatic
    @JvmName("create")
    operator fun invoke(
      projectRoot: VirtualFileUrl,
      includedRoots: List<VirtualFileUrl>,
      excludedRoots: List<VirtualFileUrl>,
      buildFiles: List<VirtualFileUrl>,
      indexAllFilesInIncludedRoots: Boolean,
      entitySource: EntitySource,
      init: (Builder.() -> Unit)? = null,
    ): Builder {
      val builder = builder()
      builder.projectRoot = projectRoot
      builder.includedRoots = includedRoots.toMutableWorkspaceList()
      builder.excludedRoots = excludedRoots.toMutableWorkspaceList()
      builder.buildFiles = buildFiles.toMutableWorkspaceList()
      builder.indexAllFilesInIncludedRoots = indexAllFilesInIncludedRoots
      builder.entitySource = entitySource
      init?.invoke(builder)
      return builder
    }
  }
  //endregion
}

//region generated code
fun MutableEntityStorage.modifyBazelProjectDirectoriesEntity(
  entity: BazelProjectDirectoriesEntity,
  modification: BazelProjectDirectoriesEntity.Builder.() -> Unit,
): BazelProjectDirectoriesEntity = modifyEntity(BazelProjectDirectoriesEntity.Builder::class.java, entity, modification)
//endregion
